// Load the AWS SDK for Node.js.
var AWS = require("aws-sdk");
// Set the AWS Region.
AWS.config.update({ region: "eu-west-3" });
const dynamodb = new AWS.DynamoDB.DocumentClient();
const dynamodb2 = new AWS.DynamoDB.DocumentClient();

// Create DynamoDB service object.
var ddb = new AWS.DynamoDB({ apiVersion: "2012-08-10" });
var ddb2 = new AWS.DynamoDB({ apiVersion: "2012-08-10" });
const s3 = new AWS.S3();

  // The content of the object you want to upload

exports.handler = async (event) => {
  try {
    // Parse the DynamoDB stream event
    const record = event.Records[0];
    const id = record.dynamodb.NewImage.id.N;
    const type = record.dynamodb.NewImage.job_type.S;
    const content = record.dynamodb.NewImage.content.S;

  const bucketName = 'bucket-hedi-n2';
const objectKey = id; // The key under which the object will be stored in the bucket

// Specify the object content
    const params = {
      TableName: "table-lambda2",
      Key: {
        id: { N: id },
      },
    };

    // Retrieve the item from DynamoDB
    const result = await ddb.getItem(params).promise();
    const item = result.Item;

    console.log("Item that triggered the Lambda:", item);
if (type === "addtodynamo"){
  console.log("we are in condition")
  console.log("this is the id",id)
   const postParams = {
      TableName: "job-content", // Replace with your actual table name
       Item: {
        'fetched_content': { S: content },
        'id': { N: id },
      },
    };
        ddb.putItem(postParams, function(err, data) {
  if (err) {
    console.log("Error", err);
  } else {
    console.log("Success", data);
  }
});


} else if (type === "addtos3"){

  console.log("we are in condition 2")
// Set the parameters for the PutObject operation
const params = {
  Bucket: bucketName,
  Key: objectKey,
  Body: JSON.stringify(item)
};

// Upload the object to the S3 bucket
s3.putObject(params, (err, data) => {
  if (err) {
    console.error('Error:', err);
  } else {
    console.log('Object uploaded successfully:', data);
  }
});
}
  // Update the processed field to "yes"

    // Define the parameters for updating the item in DynamoDB
    const updateParams = {
     TableName: 'table-lambda2',
  Item: {
    'id': { N: id },
    'processed' : {S: "yes"},
    'content' : {S : content},
    'job_type' : {S : type }
    
  }
    };

    // Update the item in DynamoDB

    const updateResult = await ddb.putItem(updateParams).promise();
    console.log('Item updated:', updateResult);
    console.log('Item updated successfully');

    const response = {
      statusCode: 200,
      body: JSON.stringify({ message: 'Item retrieved and updated successfully', item: item }),
    };

    
    return response;
  } catch (error) {
    console.error("Error:", error);
    const response = {
      statusCode: 500,
      body: JSON.stringify({ message: "Error retrieving item" }),
    };
    return response;
  }
};
