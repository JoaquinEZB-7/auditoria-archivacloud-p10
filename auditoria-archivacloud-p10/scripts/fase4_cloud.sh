===================================================== 
AUDITORIA CLOUD - FASE 4 - Bucket: archivacloud-p10-jz 
===================================================== 
 
[1] CIFRADO EN REPOSO 
COMANDO: aws s3api get-bucket-encryption --bucket archivacloud-p10-jz 
--- SALIDA: 
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": false,
                "BlockedEncryptionTypes": {
                    "EncryptionType": [
                        "SSE-C"
                    ]
                }
            }
        ]
    }
}
 
[2] VERSIONING 
COMANDO: aws s3api get-bucket-versioning --bucket archivacloud-p10-jz 
--- SALIDA (vacia = DESHABILITADO): 
 
[3] BLOCK PUBLIC ACCESS 
COMANDO: aws s3api get-public-access-block --bucket archivacloud-p10-jz 
--- SALIDA: 
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
 
[4] SERVER ACCESS LOGGING 
COMANDO: aws s3api get-bucket-logging --bucket archivacloud-p10-jz 
--- SALIDA (vacia = SIN LOGGING): 
 
[5] LIFECYCLE POLICY 
COMANDO: aws s3api get-bucket-lifecycle-configuration --bucket archivacloud-p10-jz 
--- SALIDA: 

aws: [ERROR]: An error occurred (NoSuchLifecycleConfiguration) when calling the GetBucketLifecycleConfiguration operation: The lifecycle configuration does not exist
 
[6] BUCKET POLICY 
COMANDO: aws s3api get-bucket-policy --bucket archivacloud-p10-jz 
--- SALIDA: 

aws: [ERROR]: An error occurred (NoSuchBucketPolicy) when calling the GetBucketPolicy operation: The bucket policy does not exist
 
[7] IAM - IDENTIDAD EN USO 
COMANDO: aws sts get-caller-identity 
--- SALIDA: 
{
    "UserId": "AROA2UC3BZIWOLQYMR5BQ:user4921928=joaquin.zambrano02@inacapmail.cl",
    "Account": "730335398444",
    "Arn": "arn:aws:sts::730335398444:assumed-role/voclabs/user4921928=joaquin.zambrano02@inacapmail.cl"
}
 
[8] CORS DEL BUCKET 
COMANDO: aws s3api get-bucket-cors --bucket archivacloud-p10-jz 
--- SALIDA: 
{
    "CORSRules": [
        {
            "AllowedHeaders": [
                "*"
            ],
            "AllowedMethods": [
                "GET",
                "POST",
                "PUT",
                "DELETE"
            ],
            "AllowedOrigins": [
                "http://localhost:5173"
            ]
        }
    ]
}
