//
//  IMReasonableTests.m
//  IMReasonableTests
//
//  Created by apple on 14/11/20.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "SendEmailInvitationEntity.h"
#import "PJSendInviteHttpTool.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IMReasonable.pch"

@interface IMReasonableTests : XCTestCase

@end

@implementation IMReasonableTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    SendEmailInvitationEntity *entity=[[SendEmailInvitationEntity alloc] init];
    entity.LoginEmail=LOGINEMAIL;
    entity.Password=PASSWORD;
    entity.From=FROM;
    entity.FromName=FROMNAME;
    entity.To=@"13666902838@163.com";
    entity.Subject=@"piaojinxgz";
    entity.Body=@"piaojinxgz";
    [PJSendInviteHttpTool SendEmailInviteByPostWithParam:entity success:^(id requestObject) {
        NSLog(@"success");
    } failure:^(NSError * error) {
        NSLog(@"NSError:%@",error);
    }];
    NSLog(@"piaojinxgz");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        
    }];
}

@end
