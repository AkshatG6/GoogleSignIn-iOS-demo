/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GIDTokenClaimsInternalOptions.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDTokenClaim.h"

@implementation GIDTokenClaimsInternalOptions

+ (nullable NSString *)jsonStringForClaims:(nullable NSArray<GIDTokenClaim *> *)claims {
    if (!claims || claims.count == 0) {
        return nil;
    }

    //
    // Step 1: De-duplicate the claims using a dictionary. "Essential" wins.
    //
    NSMutableDictionary<NSString *, GIDTokenClaim *> *uniqueClaims = [[NSMutableDictionary alloc] init];
    for (GIDTokenClaim *claim in claims) {
      GIDTokenClaim *existingClaim = uniqueClaims[claim.name];
      // First, if claim with same name already exists,
      if (existingClaim) {
        // if a different essentiality found, return error
        if (existingClaim.isEssential != claim.isEssential) {
          NSLog(@"[GoogleSignIn] Error: The claim '%@' was requested as both "
                                 "essential and non-essential. Please provide only one version.", claim.name);
          return nil;
        }

        // If we are here, it's a harmless duplicate (e.g., two essential requests). We can ignore it.
      } else {
        // This is the first time we've seen this claim, so add it.
        uniqueClaims[claim.name] = claim;
      }
    }

    //
    // Step 2: Build the dictionary structure required for OIDC JSON.
    // The format is: { "id_token": { "claim_name": { "essential": true }, ... } }
    //
    NSMutableDictionary<NSString *, id> *tokenClaimsDictionary = [[NSMutableDictionary alloc] init];
    for (GIDTokenClaim *claim in uniqueClaims.allValues) {
        if (claim.isEssential) {
            // For essential claims, the value is a dictionary: {"essential": true}
            tokenClaimsDictionary[claim.name] = @{ @"essential": @YES };
        } else {
            // For non-essential claims, the value is null.
            tokenClaimsDictionary[claim.name] = [NSNull null];
        }
    }

    // The final structure must be wrapped in a top-level "id_token" key.
    NSDictionary<NSString *, id> *finalRequestDictionary = @{ @"id_token": tokenClaimsDictionary };

    //
    // Step 3: Serialize the final dictionary into a JSON string.
    //
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalRequestDictionary
                                                       options:0 // Use 0 for compact output
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Error creating JSON from claims: %@", error.localizedDescription);
        return nil;
    }

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
