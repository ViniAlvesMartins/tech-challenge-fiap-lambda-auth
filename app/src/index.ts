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

    var result;
    try {
      result = await verifier.verify(token);
      console.log("Token is valid.");
    } catch {
      console.log("Token not valid!");
      return 'Unauthorized';
    }
    authResponse = buildAllowAllPolicy(event, result.username, "Allow")
  }

  return authResponse;
};

function buildAllowAllPolicy(event: any, principalId: string, effect: string) {
  const policy = {
    principalId: principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: [event.methodArn]
        }
      ]
    }
  }
  return policy
}
