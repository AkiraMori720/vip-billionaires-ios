//
//  global.h
//  SocialNetwork
//
//  Created by Gregor H on 6/21/16.
//  Copyright © 2016 Eric Schanet. All rights reserved.
//

#ifndef global_h
#define global_h

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)
#define IS_IPHONE6P ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 736)

#define def_Title_Font      [UIFont fontWithName:@"Montserrat-Medium" size:21]
#define def_TopBar_Color    [UIColor blackColor]
#define def_GoldenDark_Color   [UIColor colorWithRed:0.6313 green:0.5137 blue:0.0588 alpha:1]
#define def_Golden_Color   [UIColor colorWithRed:0.9411 green:0.8431 blue:0.4509 alpha:1]
#define def_Golden_Color3   [UIColor colorWithRed:0.9411 green:0.8431 blue:0.4509 alpha:0.3f]
#define def_Golden_Color5   [UIColor colorWithRed:0.9411 green:0.8431 blue:0.4509 alpha:0.5f]
#define def_Golden_Color8   [UIColor colorWithRed:0.9411 green:0.8431 blue:0.4509 alpha:0.8f]

#define SCR_W   [[UIScreen mainScreen] bounds].size.width
#define SCR_H   [[UIScreen mainScreen] bounds].size.height

#endif /* global_h */
