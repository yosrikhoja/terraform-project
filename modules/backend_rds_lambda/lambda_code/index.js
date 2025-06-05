const mysql = require('mysql');
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    const connection = mysql.createConnection({
        host: process.env.DB_HOST,
        user: 'admin',
        password: 'password',
        database: 'mydb'
    });

    connection.connect();

    connection.query('SELECT * FROM my_table', (err, results) => {
        if (err) throw err;

        const params = {
            Bucket: 'my-static-files-bucket',
            Key: `data-${Date.now()}.json`,
            Body: JSON.stringify(results)
        };

        s3.putObject(params).promise().then(() => {
            console.log('Data saved to S3');
        }).catch(console.error);
    });

    connection.end();
};
