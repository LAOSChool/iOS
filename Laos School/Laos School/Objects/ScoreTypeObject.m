//
//  ScoreTypeObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreTypeObject.h"
#import "LocalizeHelper.h"

@implementation ScoreTypeObject

- (id)init {
    self = [super init];
    if (self) {
        self.scoreName = @"";
        self.scoreType = ScoreType_Normal;
        self.scoreKey = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {

    }
    
    return self;
}

- (NSString *)scoreName {
    NSString *res = @"";
    
    if ([_scoreKey isEqualToString:SCORE_KEY_SEP]) {
        res = LocalizedString(@"September score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_OCT]) {
        res = LocalizedString(@"October score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_NOV]) {
        res = LocalizedString(@"November score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_DEC]) {
        res = LocalizedString(@"December score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE4M1]) {
        res = LocalizedString(@"Average 4 months");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_TERM_EXAM1]) {
        res = LocalizedString(@"Term exam 1");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE_TERM1]) {
        res = LocalizedString(@"Average term 1");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_FEB]) {
        res = LocalizedString(@"February score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_MAR]) {
        res = LocalizedString(@"March score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_APR]) {
        res = LocalizedString(@"April score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_MAY]) {
        res = LocalizedString(@"May score");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE4M2]) {
        res = LocalizedString(@"Average 4 months");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_TERM_EXAM2]) {
        res = LocalizedString(@"Term exam 2");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE_TERM2]) {
        res = LocalizedString(@"Average term 2");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_OVERALL]) {
        res = LocalizedString(@"Overall");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_RETEST]) {
        res = LocalizedString(@"Retest");
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_GRADUATION]) {
        res = LocalizedString(@"Graduation");
        
    }
    
    return res;
}

- (NSString *)scoreShortName {
    NSString *res = @"";
    
    if ([_scoreKey isEqualToString:@"Sep"]) {
        res = LocalizedString(@"Sep");
        
    } else if ([_scoreKey isEqualToString:@"Oct"]) {
        res = LocalizedString(@"Oct");
        
    } else if ([_scoreKey isEqualToString:@"Nov"]) {
        res = LocalizedString(@"Nov");
        
    } else if ([_scoreKey isEqualToString:@"Dec"]) {
        res = LocalizedString(@"Dec");
        
    } else if ([_scoreKey isEqualToString:@"Feb"]) {
        res = LocalizedString(@"Feb");
        
    } else if ([_scoreKey isEqualToString:@"Mar"]) {
        res = LocalizedString(@"Mar");
        
    } else if ([_scoreKey isEqualToString:@"Apr"]) {
        res = LocalizedString(@"Apr");
        
    } else if ([_scoreKey isEqualToString:@"May"]) {
        res = LocalizedString(@"May");
        
    } else if ([_scoreKey isEqualToString:@"Aver4Months1"]) {
        res = LocalizedString(@"Ave_m1");
        
    } else if ([_scoreKey isEqualToString:@"TermExam1"]) {
        res = LocalizedString(@"Test term I");
        
    } else if ([_scoreKey isEqualToString:@"AverageTerm1"]) {
        res = LocalizedString(@"Ave term I");
        
    } else if ([_scoreKey isEqualToString:@"Aver4Months2"]) {
        res = LocalizedString(@"Ave_m2");
        
    } else if ([_scoreKey isEqualToString:@"TermExam2"]) {
        res = LocalizedString(@"Test term II");
        
    } else if ([_scoreKey isEqualToString:@"AverageTerm2"]) {
        res = LocalizedString(@"Ave term II");
        
    } else if ([_scoreKey isEqualToString:@"Overall"]) {
        res = LocalizedString(@"Ave year");
        
    } else if ([_scoreKey isEqualToString:@"Retest"]) {
        res = LocalizedString(@"Retest");
        
    } else if ([_scoreKey isEqualToString:@"Graduation"]) {
        res = LocalizedString(@"Test grad");
        
    }
    
    return res;
}

@end