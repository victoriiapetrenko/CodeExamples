//
//  WSACoreDataManager.h
//

@import Foundation;
@class CSAsynchronousDataTransaction;
@protocol CSFetchClause;
@class JobId;

#import "WSADataProvider.h"
#import "WSADeploymentItem+CoreDataClass.h"
#import "WSADeploymentItemEvent+CoreDataClass.h"
#import "WSADeploymentItemEventAborted+CoreDataClass.h"
#import "WSADeploymentItemEventAnswerQuestionnaire+CoreDataClass.h"
#import "WSADeploymentItemEventArrived+CoreDataClass.h"
#import "WSADeploymentItemEventDelay+CoreDataClass.h"
#import "WSADeploymentItemEventEDR+CoreDataClass.h"
#import "WSADeploymentItemEventGPSCoordinates+CoreDataClass.h"
#import "WSADeploymentItemEventRejected+CoreDataClass.h"
#import "WSAFreeText+CoreDataClass.h"
#import "WSAJobUpdate+CoreDataClass.h"
#import "WSAPicture+CoreDataClass.h"
#import "WSAUser+CoreDataClass.h"

extern NSString *const CoreDataSavedNotification;



#pragma mark - Interface

@interface WSACoreDataManager : NSObject

#pragma mark Setup

+ (void)setup;

#pragma mark Add data

+ (void)addSyntiaNotifications:(NSArray<NSDictionary *> *)syntiaNotifications pushUpdate:(BOOL)isPushUpdate completion:(NSErrorBlock)completion;

#pragma mark Manage users

+ (void)addUserWithName:(NSString *)userName andFullName:(NSString *)fullName withCompletion:(NSErrorBlock)completion;
+ (void)deleteUserWithName:(NSString *)userName;
+ (NSString *)fullNameForUser:(NSString *)userName;

#pragma mark Tools

+ (void)purgeDataForTransaction:(CSAsynchronousDataTransaction *)transaction;

@end
