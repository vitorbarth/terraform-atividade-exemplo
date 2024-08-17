import os
import boto3
from PIL import Image
import io

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket_original = os.environ["S3_BUCKET_IMAGEM_ORIGINAL"]
    bucket_reducao = os.environ["S3_BUCKET_IMAGEM_REDUZIDA"]

    key = event['Records'][0]['s3']['object']['key']

    # Baixar a imagem do S3
    response = s3.get_object(Bucket=bucket_original, Key=key)
    image_content = response['Body'].read()

    # Abrir a imagem
    image = Image.open(io.BytesIO(image_content))
    
    # Criar a nova imagem com redução de tamanho
    image.thumbnail((128, 128))
    
    # Salvar a nova imagem em um buffer de memória
    buffer = io.BytesIO()
    image.save(buffer, 'PNG')
    buffer.seek(0)
    
    # Nome da imagem
    reducao_key = 'reducao-' + key
    
    # Upload da imagem para o outro bucket
    s3.put_object(Bucket=bucket_reducao, Key=reducao_key, Body=buffer, ContentType='image/png')

    return {
        'statusCode': 200,
        'body': f'imagem {reducao_key} criada com sucesso.'
    }


# if __name__ == '__main__':
#     evento = {
#         "Records" :[{
#             "s3": {
#                 "object":{ 
#                     "key":"exemplo-farm.png"
#                 }
#             }
#     }]
#     }
#     lambda_handler(evento, None)