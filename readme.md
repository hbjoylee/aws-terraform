# Replace email address
Update email in variable.tf to receive SNS subscription confirmation email.

# init
```
terraform init
```
# plan
```
mv plan.sh_example plan.sh
```
Replace aws key and secret in plan.sh
```
./plan.sh
```


# apply to create all resources
```
mv apply.sh_example apply.sh
```
replace aws key and secret in apply.sh
```
./apply.sh
```

# destroy everything
```
mv destroy.sh_example destroy.sh
```

replace aws key and secret in apply.sh
```
./destroy.sh
```
