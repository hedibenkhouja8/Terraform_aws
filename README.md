﻿# Terraform-aws
Sur le fichier terraform :
j'ai caché le provider puisque c'est interdit par aws;
j'ai créer une lambda qui est lié a une api gateway et une dynamo db avec les roles et les policies necessaire pour effectuer la requete post avec cet schema :
{
    
    "id" : 5764520013128,
    "job_type" : "addtos3",
    "content" : "test1",
    "processed" : "no"
}
apres j'ai creer une autre dynamo table qui va faire un trigger sur une 2eme lambda qui va stocker le job quand il est de type "addtodynamodb"

Sur la console :
j'ai creer un bucket s3
j'ai creer une 2 eme Lambda qui vas etre triggered a partir de la premiere table 
et selon le type de job "addtos3" ou add "addtodynamodb" soit elle stocke le job dans l'S3 ou dans la 2eme table
je laisse le code de la 2eme lambda dans la repo avec le nom "index2.js"