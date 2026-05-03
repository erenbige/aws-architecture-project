import json

def lambda_handler(event, context):
    # Bu fonksiyon API Gateway üzerinden tetiklendiğinde çalışır
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/html',
            'Access-Control-Allow-Origin': '*'
        },
        'body': '<h1>Most Optimized Architecture!</h1><p>Bu yanit AWS Lambda ve API Gateway uzerinden serverless olarak donulmektedir. 🚀</p>'
    }