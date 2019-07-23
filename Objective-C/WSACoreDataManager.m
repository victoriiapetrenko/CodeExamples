//
//  WSACoreDataManager.m
//

@import CoreStore;
#import "WSACoreDataManager.h"
#import "WSANetworkManager.h"
#import "WSADeploymentItemEventCustomerCall+CoreDataClass.h"
#import "WSADeploymentItemEventCustomerCall+CoreDataProperties.h"
#import "DeploymentItemEventMobilityGuarantee+CoreDataClass.h"
#import "DeploymentItemEventMobilityGuarantee+CoreDataProperties.h"
#import "RSAMobile24-Swift.h"

NSString * const CoreDataSavedNotification = @"CoreDataSavedNotification";

#pragma mark - Implementation

@implementation WSACoreDataManager

#pragma mark Setup

+ (void)setup
{
    [CoreDataStore setupCoreStore];
}

#pragma mark Add data

+ (void)addSyntiaNotifications:(NSArray<NSDictionary *> *)syntiaNotifications pushUpdate:(BOOL)isPushUpdate completion:(NSErrorBlock)completion {
    [SyntiaNotificationJSONParser parseSyntiaNotifications:syntiaNotifications isPushUpdate:isPushUpdate completion:^(BOOL isSaved) {
        if (completion) {
            completion(isSaved ? nil : [NSError errorWithDomain:WSADataProviderResponseDomain code:WSADataProviderResponseGenericError userInfo:nil]);
        }
    }];
}

#pragma mark Manage users

+ (void)addUserWithName:(NSString *)userName andFullName:(NSString *)fullName withCompletion:(NSErrorBlock)completion
{
    [CSCoreStore.defaultStack beginAsynchronous:^(CSAsynchronousDataTransaction * _Nonnull transaction) {
        
        CSFrom *fromUsers = [[CSFrom alloc] initWithEntityClass:[WSAUser class]];
        WSAUser *user = [transaction fetchOneFrom:fromUsers fetchClauses:@[CSWhereFormat(@"name == %@", userName)]];
        
        if (!user) {
            user = [transaction createInto:[[CSInto alloc] initWithEntityClass:[WSAUser class]]];
            user.name = userName;
        }
        
        user.fullName = fullName;
        [transaction commitWithSuccess:^{
            completion(nil);
        } failure:^(CSError * _Nonnull error) {
            completion(error);
        }];
    }];
}

+ (void)deleteUserWithName:(NSString *)userName
{
    [CSCoreStore.defaultStack beginAsynchronous:^(CSAsynchronousDataTransaction * _Nonnull transaction) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", userName];
        CSFrom *fromUsers = [[CSFrom alloc] initWithEntityClass:[WSAUser class]];
        NSArray<WSAUser *> *users = [transaction fetchAllFrom:fromUsers fetchClauses:@[CSWherePredicate(predicate)]];
        
        if (users) {
            [transaction deleteObjects:users];
            [transaction commitWithSuccess:^{
                
            } failure:^(CSError * _Nonnull error) {
                
            }];
        }
    }];
}

+ (NSString *)fullNameForUser:(NSString *)userName
{
    CSFrom *fromUsers = [[CSFrom alloc] initWithEntityClass:[WSAUser class]];
    WSAUser *user = [CSCoreStore.defaultStack fetchOneFrom:fromUsers fetchClauses:@[CSWhereFormat(@"name == %@", userName)]];
    
    return user.fullName;
}

#pragma mark Tools

+ (void)purgeDataForTransaction:(CSAsynchronousDataTransaction *)transaction
{
    NSArray<NSNumber *> *allowedStatus = @[@(WSADeploymentItemEventTypeMobileDeploymentFinished),
                                           @(WSADeploymentItemEventTypeRejected),
                                           @(WSADeploymentItemEventTypeRejectedByTimeOut),
                                           @(WSADeploymentItemEventTypeAborted),
                                           @(WSADeploymentItemEventTypeAbortedByM24Received),
                                           @(WSADeploymentItemEventTypeAbortedByM24Read),
                                           @(WSADeploymentItemEventTypeAbortedByM24Acknowledged)];
    
    NSDate *purgeDate = [NSDate dateWithTimeIntervalSinceNow:(WSAPurgeTime * -1)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status IN %@ AND statusDate < %@", allowedStatus, purgeDate];
    
    NSArray<WSADeploymentItem *> *items = [transaction fetchAllFrom:CSFromClass([WSADeploymentItem class]) fetchClauses:@[CSWherePredicate(predicate)]];
    [transaction deleteObjects:items];
    [transaction commitWithSuccess:^{
        
    } failure:^(CSError * _Nonnull error) {
        
    }];
}

@end
