const AWS = require('aws-sdk');

// Create an instance of the DynamoDB DocumentClient
const dynamodb = new AWS.DynamoDB.DocumentClient();
exports.handler = async (event) => {
   try {
    // Parse the request body
    const requestBody = JSON.parse(event.body);

    // Define the parameters for putting an item in DynamoDB
    const params = {
      TableName: "table-lambda2", // Replace with your actual table name
      Item: requestBody,
    };

    // Put the item in DynamoDB
    await dynamodb.put(params).promise();
    console.log(event.body)
    const response = {
      statusCode: 200,
      body: JSON.stringify({ message: 'Item saved successfully in DynamoDB' }),
    };

    return response;
  } catch (error) {
    console.error('Error:', error);
    const response = {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error saving item in DynamoDB' }),
    };
    return response;
  }
};
