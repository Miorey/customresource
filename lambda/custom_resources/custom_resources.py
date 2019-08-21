import boto3
import cfnresponse


def lambda_handler(event, context):
    if event["RequestType"] == 'Delete':
        """"
        In case of Delete signal, we do not have to do nothing because this script is not creating any persistent resource.
        We can directly return with success signal.
        """
        return cfnresponse.send(event, context, cfnresponse.SUCCESS, None)
    elif event["ResourceType"] == 'Custom::LambdaVersion':
        """
        Publish a new version if possible
        """
        return lambda_version(event, context)

    # if no custom resource is found I raise an exception.
    raise cfnresponse.send(
        event,
        context,
        cfnresponse.FAILED,
        "This function only supports Custom::LambdaVersion and Custom::ApiDeployment resource types.")


def lambda_version(event, context):
    """
    Publish a new version of the given lambda: ResourceProperties.FunctionName
    The new not dynamic last is linked to this new version: ResourceProperties.LastVersionAlias
    """
    try:
        client = boto3.client('lambda')

        # check if a description is available
        description = '' if 'Description' not in event['ResourceProperties'] else event['ResourceProperties']['Description']

        # publish the description with the description
        response = client.publish_version(
            FunctionName=event['ResourceProperties']['FunctionName'],
            Description=description
        )
        return cfnresponse.send(
            event,
            context,
            cfnresponse.SUCCESS,
            {'Version': response["Version"]},
            response["FunctionArn"])

    except Exception as err:
        # Something happens
        return cfnresponse.send(
            event,
            context,
            cfnresponse.FAILED,
            err)
