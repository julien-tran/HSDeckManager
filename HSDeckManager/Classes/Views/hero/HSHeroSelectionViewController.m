//
//  HSHeroSelectionViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSHeroSelectionViewController.h"

// Data
#import "HSDeck.h"
#import "HSDataCenter.h"

@interface HSHeroSelectionViewController ()
@property (nonatomic, strong) HSDeck *selectedDeck;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *classHeroButtons;
@end

@implementation HSHeroSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HSDeck *newDeck = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HSDeck class]) inManagedObjectContext:mainDataCenter.managedObjectContext];
    newDeck.lastDate = [NSDate date];
    newDeck.name = @"New deck";
    newDeck.hero = [[HSDataCenter heroIDList] objectAtIndex:[self.classHeroButtons indexOfObject:sender]];
    self.selectedDeck = newDeck;
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"heroSelectionSegue"])
    {
        UITabBarController *tabController = segue.destinationViewController;
        for (UIViewController *viewController in tabController.viewControllers)
        {
            if ([viewController respondsToSelector:@selector(setDeck:)])
            {
                [viewController performSelector:@selector(setDeck:) withObject:self.selectedDeck afterDelay:0];
            }
        }
    }
}

@end