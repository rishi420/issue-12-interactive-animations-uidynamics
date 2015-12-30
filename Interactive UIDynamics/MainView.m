//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MainView.h"
#import "DraggableView.h"
#import "PaneBehavior.h"


@interface MainView () <DraggableViewDelegate, UITableViewDelegate>

@property (nonatomic) PaneState paneState;
@property (nonatomic) DraggableView *pane;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic, strong) PaneBehavior *paneBehavior;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}



- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];

    CGSize size = self.bounds.size;
    self.paneState = PaneStateClosed;
    self.pane = [[DraggableView alloc] initWithFrame:CGRectMake(0, size.height * .75, size.width, size.height)];
    self.pane.backgroundColor = [UIColor grayColor];
    self.pane.layer.cornerRadius = 8;
    self.pane.delegate = self;
    [self addSubview:self.pane];

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.pane.bounds];
    self.scrollView.contentSize = CGSizeMake(size.width * 2, size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor orangeColor];
    //self.scrollView.delegate = self;
    [self.pane addSubview:self.scrollView];
    
    //self.scrollView.scrollEnabled = NO;
    
    
    UIView *smallRectView = [[UIView alloc] initWithFrame:CGRectMake(100, 10, 10, 10)];
    smallRectView.backgroundColor = [UIColor yellowColor];
    [self.scrollView addSubview:smallRectView];
    
    UIView *smallRectView2 = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 10, 10)];
    smallRectView2.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:smallRectView2];
    
    UIView *smallRectView3 = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 10, 10)];
    smallRectView3.backgroundColor = [UIColor blueColor];
    [self.scrollView addSubview:smallRectView3];
    
    UIView *smallRectView4 = [[UIView alloc] initWithFrame:CGRectMake(100, 300, 10, 10)];
    smallRectView4.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:smallRectView4];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.dataSource = self;
    [self.scrollView addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
}

- (void)animatePaneWithInitialVelocity:(CGPoint)initialVelocity
{
    if (!self.paneBehavior) {
        PaneBehavior *behavior = [[PaneBehavior alloc] initWithItem:self.pane];
        self.paneBehavior = behavior;
    }
    self.paneBehavior.targetPoint = self.targetPoint;
    self.paneBehavior.velocity = initialVelocity;
    [self.animator addBehavior:self.paneBehavior];
}

- (CGPoint)targetPoint
{
    CGSize size = self.bounds.size;
    return self.paneState == PaneStateClosed > 0 ? CGPointMake(size.width/2, size.height*1.5 - 200) : CGPointMake(size.width/2, size.height/2 + 50);
}


#pragma mark DraggableViewDelegate

- (void)draggableView:(DraggableView *)view draggingEndedWithVelocity:(CGPoint)velocity
{
    
    PaneState targetState = velocity.y >= 0 ? PaneStateClosed : PaneStateOpen;
    
    
    if (self.paneState != targetState) {
        if (targetState == PaneStateOpen) {
            //self.scrollView.scrollEnabled = YES;
            self.tableView.scrollEnabled = YES;
        } else {
            //self.scrollView.scrollEnabled = NO;
        }
    }
    
    NSLog(@"scorll position offset %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    NSLog(@"scorll velocity %f", velocity.y);
    NSLog(@"scorll rect %@", NSStringFromCGRect(self.pane.frame));
    
    CGSize size = self.bounds.size;
    CGPoint closePoint = CGPointMake(size.width/2, size.height*1.5 - 200);
    CGPoint openPoint = CGPointMake(size.width/2, size.height/2 + 50);
    
    NSLog(@"closePoint %@", NSStringFromCGPoint(closePoint));
    NSLog(@"openPoint %@", NSStringFromCGPoint(openPoint));
    NSLog(@"targetPoint %@", NSStringFromCGPoint(self.targetPoint));
    
    NSLog(@"targetState = %ld", (long)targetState);
    self.paneState = targetState;
    [self animatePaneWithInitialVelocity:velocity];
}

- (void)draggableViewBeganDragging:(DraggableView *)view
{
    [self.animator removeAllBehaviors];
}


#pragma mark Actions

- (void)didTap:(UITapGestureRecognizer *)tapRecognizer
{
    self.paneState = self.paneState == PaneStateOpen ? PaneStateClosed : PaneStateOpen;
    [self animatePaneWithInitialVelocity:self.paneBehavior.velocity];
}


//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scorll position offset %@, inset %f", NSStringFromCGPoint(self.scrollView.contentOffset), self.scrollView.contentInset.top);
//    if (scrollView.contentOffset.y == 0) {
//        self.scrollView.scrollEnabled = NO;
//        [self didTap:nil];
//    }
//}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scorll position offset %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    
    if (scrollView.contentOffset.y < 0 && self.paneState == PaneStateOpen) {
        //self.scrollView.scrollEnabled = NO;
        self.tableView.scrollEnabled = NO;
        [self didTap:nil];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
    
    return cell;
}

@end