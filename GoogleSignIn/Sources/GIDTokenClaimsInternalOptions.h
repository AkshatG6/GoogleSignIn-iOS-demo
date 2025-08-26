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

#import <Foundation/Foundation.h>

@class GIDTokenClaim;

NS_ASSUME_NONNULL_BEGIN

/**
 * An internal utility class for processing and serializing GIDTokenClaim objects
 * into the JSON format required for an OIDC request.
 */
@interface GIDTokenClaimsInternalOptions : NSObject

/**
 * Processes an array of claims, handling duplicates, and returns a JSON string
 * formatted for the OIDC 'claims' parameter.
 *
 * @param claims The array of GIDTokenClaim objects provided by the developer.
 * @return A JSON string representing the claims request, or nil if the input is empty.
 */
+ (nullable NSString *)jsonStringForClaims:(nullable NSArray<GIDTokenClaim *> *)claims;

@end

NS_ASSUME_NONNULL_END
