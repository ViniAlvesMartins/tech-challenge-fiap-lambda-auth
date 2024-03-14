import { CognitoJwtVerifier } from "aws-jwt-verify";

export const handler = async (event: any) => {
  var authResponse;
  var token = event.headers.authorization;

  if (token == "anonymous") {
    console.log("Anonymous login sucess!");
    authResponse = buildAllowAllPolicy(event, "anonymous", "Allow");
  } else {
    const verifier = CognitoJwtVerifier.create({
      userPoolId: "us-east-1_xum9ekqkH",
      tokenUse: "access",
      clientId: "371g5rnln41qgrjfa7qe2qhf2",
    })

    try {
      const payload = await verifier.verify(token);
      console.log("Token is valid. Payload:", payload);
    } catch {
      console.log("Token not valid!");
      return 'Unauthorized';
    }
    authResponse = buildAllowAllPolicy(event, "UserCognito", "Allow")
  }

  return authResponse;
};

function buildAllowAllPolicy(event: any, principalId: string, effect: string) {
  var tmp = event.methodArn.split(':')
  var apiGatewayArnTmp = tmp[5].split('/')
  var awsAccountId = tmp[4]
  var awsRegion = tmp[3]
  var restApiId = apiGatewayArnTmp[0]
  var stage = apiGatewayArnTmp[1]
  var apiArn = 'arn:aws:execute-api:' + awsRegion + ':' + awsAccountId + ':' +
    restApiId + '/' + stage + '/*/*'
  const policy = {
    principalId: principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: [apiArn]
        }
      ]
    }
  }
  return policy
}
