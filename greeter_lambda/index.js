// AWS SDK v3 with CommonJS syntax
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const { v4: uuidv4 } = require('uuid');

// Initialize clients
const dynamoClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(dynamoClient);
const snsClient = new SNSClient({ region: "us-east-1" });

exports.handler = async (event) => {
    const email = event.email || 'rohit.korlahalli21@gmail.com';
    const region = process.env.AWS_REGION;

    const itemId = uuidv4();

    const params = {
        TableName: process.env.DYNAMODB_TABLE,
        Item: {
            id: itemId,
            email: email,
            timestamp: new Date().toISOString()
        }
    };

    try {
        // Write to DynamoDB using v3 syntax
        await docClient.send(new PutCommand(params));

        // Publish to SNS using v3 syntax
        const snsParams = {
            Message: JSON.stringify({
                email: email,
                source: "Lambda",
                region: region,
                repo: "https://github.com/rokorlahalli/unleash-assessment"
            }),
            TopicArn: process.env.SNS_TOPIC_ARN
        };
        await snsClient.send(new PublishCommand(snsParams));

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Successfully processed the request.',
                region: region
            })
        };
    } catch (error) {
        console.error("Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Internal Server Error' })
        };
    }
};
