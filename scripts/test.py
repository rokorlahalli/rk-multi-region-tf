import asyncio
import json
import time
from typing import Any, Dict, Tuple

import aiohttp


# =========================
# CONFIG
# =========================
COGNITO_REGION = "us-east-1"
CLIENT_ID = "3vrf473etks8vvnvpr81vc4fks"
USERNAME = "ro******@gmail.com"
PASSWORD = "**********"

US_GREET_URL = "https://mgk32t7w57.execute-api.us-east-1.amazonaws.com/prod/greet"
EU_GREET_URL = "https://0r6rzwltx0.execute-api.eu-west-1.amazonaws.com/prod/greet"

US_DISPATCH_URL = "https://mgk32t7w57.execute-api.us-east-1.amazonaws.com/prod/dispatch"
EU_DISPATCH_URL = "https://0r6rzwltx0.execute-api.eu-west-1.amazonaws.com/prod/dispatch"


# =========================
# AUTH
# =========================
async def get_jwt(session: aiohttp.ClientSession) -> str:
    url = f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/"
    headers = {
        "Content-Type": "application/x-amz-json-1.1",
        "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
    }
    payload = {
        "AuthFlow": "USER_PASSWORD_AUTH",
        "ClientId": CLIENT_ID,
        "AuthParameters": {
            "USERNAME": USERNAME,
            "PASSWORD": PASSWORD,
        },
    }

    async with session.post(url, headers=headers, json=payload) as resp:
        text = await resp.text()
        if resp.status != 200:
            raise RuntimeError(f"Cognito auth failed: {resp.status} {text}")

        data = json.loads(text)
        try:
            return data["AuthenticationResult"]["IdToken"]
        except KeyError:
            raise RuntimeError(f"Could not extract IdToken from response: {data}")


# =========================
# API CALLS
# =========================
async def call_api(
    session: aiohttp.ClientSession,
    method: str,
    url: str,
    token: str,
    expected_region: str,
    label: str,
) -> Dict[str, Any]:
    headers = {
        "Authorization": token,
        "Content-Type": "application/json",
    }

    start = time.perf_counter()
    async with session.request(method, url, headers=headers) as resp:
        latency_ms = round((time.perf_counter() - start) * 1000, 2)
        text = await resp.text()

        try:
            body = json.loads(text)
        except json.JSONDecodeError:
            body = {"raw_response": text}

        actual_region = body.get("region")
        region_match = actual_region == expected_region

        return {
            "label": label,
            "url": url,
            "method": method,
            "status_code": resp.status,
            "latency_ms": latency_ms,
            "expected_region": expected_region,
            "actual_region": actual_region,
            "region_match": region_match,
            "body": body,
        }


def print_result(result: Dict[str, Any]) -> None:
    print("=" * 80)
    print(f"Test:            {result['label']}")
    print(f"Method:          {result['method']}")
    print(f"URL:             {result['url']}")
    print(f"Status Code:     {result['status_code']}")
    print(f"Latency (ms):    {result['latency_ms']}")
    print(f"Expected Region: {result['expected_region']}")
    print(f"Actual Region:   {result['actual_region']}")
    print(f"Region Match:    {result['region_match']}")
    print("Response Body:")
    print(json.dumps(result["body"], indent=2))


# =========================
# MAIN
# =========================
async def main() -> None:
    timeout = aiohttp.ClientTimeout(total=60)

    async with aiohttp.ClientSession(timeout=timeout) as session:
        print("Authenticating with Cognito...")
        token = await get_jwt(session)
        print("Authentication successful.\n")

        # Concurrent /greet
        print("Calling /greet concurrently in both regions...\n")
        greet_tasks = [
            call_api(session, "GET", US_GREET_URL, token, "us-east-1", "greet-us"),
            call_api(session, "GET", EU_GREET_URL, token, "eu-west-1", "greet-eu"),
        ]
        greet_results = await asyncio.gather(*greet_tasks)

        # Concurrent /dispatch
        print("Calling /dispatch concurrently in both regions...\n")
        dispatch_tasks = [
            call_api(session, "POST", US_DISPATCH_URL, token, "us-east-1", "dispatch-us"),
            call_api(session, "POST", EU_DISPATCH_URL, token, "eu-west-1", "dispatch-eu"),
        ]
        dispatch_results = await asyncio.gather(*dispatch_tasks)

        all_results = greet_results + dispatch_results

        for result in all_results:
            print_result(result)

        print("\n" + "=" * 80)
        print("ASSERTION SUMMARY")
        print("=" * 80)

        failed = False
        for result in all_results:
            # For assessment, ideal case is both lambdas return region in body
            if result["status_code"] != 200:
                failed = True
                print(f"[FAIL] {result['label']} returned status {result['status_code']}")
                continue

            if result["actual_region"] is None:
                failed = True
                print(f"[FAIL] {result['label']} response did not include 'region'")
                continue

            if not result["region_match"]:
                failed = True
                print(
                    f"[FAIL] {result['label']} expected region "
                    f"{result['expected_region']} but got {result['actual_region']}"
                )
            else:
                print(
                    f"[PASS] {result['label']} region matched "
                    f"({result['actual_region']}) | latency={result['latency_ms']} ms"
                )

        if failed:
            raise SystemExit(1)

        print("\nAll tests passed successfully.")


if __name__ == "__main__":
    asyncio.run(main())
