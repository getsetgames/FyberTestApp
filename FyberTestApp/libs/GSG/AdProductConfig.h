//
//  AdProductConfig.h
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdProductConfig : NSObject
{
  NSString* productId;
  int currentCount;
  int frequency;
  NSArray *orderList;
  BOOL visible;
}

@property (nonatomic, retain) NSString* productId;
@property (nonatomic, assign) int currentCount;
@property (nonatomic, assign) int frequency;
@property (nonatomic, retain) NSArray *orderList;
@property (nonatomic, assign) BOOL visible;

-(id)initWithProductId:(NSString*)product andFrequency:(int)freq;
-(void)persistCount;

@end
