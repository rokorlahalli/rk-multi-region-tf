const { ECSClient, RunTaskCommand } = require("@aws-sdk/client-ecs");

const ecs = new ECSClient({ region: process.env.AWS_REGION });

exports.handler = async () => {
  try {
    const subnetIds = process.env.SUBNET_IDS.split(",");

    const params = {
      cluster: process.env.CLUSTER_ARN,
      taskDefinition: process.env.TASK_DEFINITION_ARN,
      launchType: "FARGATE",
      count: 1,
      networkConfiguration: {
        awsvpcConfiguration: {
          subnets: subnetIds,
          securityGroups: [process.env.SECURITY_GROUP_ID],
          assignPublicIp: "ENABLED"
        }
      }
    };

    const command = new RunTaskCommand(params);
    const response = await ecs.send(command);

    if (response.failures && response.failures.length > 0) {
      console.error("ECS task failures:", JSON.stringify(response.failures));
      return {
        statusCode: 500,
        body: JSON.stringify({
          message: "Failed to run ECS task",
          failures: response.failures
        })
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "ECS task triggered successfully",
        tasks: response.tasks?.map(t => t.taskArn) || [],
        region: process.env.AWS_REGION
      })
    };
  } catch (error) {
    console.error("Dispatcher error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Internal server error",
        error: error.message
      })
    };
  }
};
