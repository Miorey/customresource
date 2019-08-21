# Cloudformation lambda version
This cloudformation custom resource allow you to automate version
publishing in your cloudformation template.

To deploy the lambda you'll need aws cli. Take care the name 
of the deployed lambda is `custom_resources`, please check that
you don't have any other lambda with this name. 

**Deploy**
```bash
make deploy
```

Usage of the custom resource:
```json
    "MyExampleLambdaVersion": {
      "Type": "Custom::LambdaVersion",
      "Properties": {
        "ServiceToken": {
            "Fn::Sub": "arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:custom_resources"
        },
        "FunctionName": {
          "Ref": "MyExample"
        },
        "Description":  {
            "Fn::Sub": "Updated at ${Timestamp}"
        }
      }
    }
```
If you want to be sure that a version is published every time 
you deploy I highly recommends you to use the `Description` 
attribute like below.

To deploy our example just execute
```
make example
```