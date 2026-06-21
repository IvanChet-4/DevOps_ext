Добавляем переменные:  
  
```
export TF_VAR_yandex_cloud_token=$(yc iam create-token)  
export TF_VAR_cloud_id=$(yc config get cloud-id)  
export TF_VAR_folder_id=$(yc config get folder-id)  
```
  
Запускаем из директории с main.tf, variables.tf:  
  
```
terraform init  
terraform plan  
terraform apply  
```
