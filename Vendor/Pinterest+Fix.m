//
//  Pinterest+Fix.m
//  
//
//  Created by Zachary Davison on 6/26/15.
//
//

#import "Pinterest+Fix.h"

@implementation Pinterest(Fix)

- (id)initWithClientId_fixed:(NSString *)clientId{
  [clientId retain];
  return [self initWithClientId:clientId];
}

@end
