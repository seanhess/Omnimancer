//
//  OMViewController.m
//  Omnimancer
//
//  Created by Sean Hess on 4/9/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

// Goal, draw a second cube, one unit to the right

#import "OMViewController.h"
#import "OMShard.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


// make a FUNCTION that returns an array of stuff, based on starting position yeah....
// concat with another array


// Do boxes know their position in the grid
// No, then don't. Why would they? Because it's easier to keep track that way

@interface OMViewController () {
    GLuint _program;
    
//    GLKMatrix4 _modelViewProjectionMatrix;
//    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) OMShard* shard;
@property (nonatomic) GLKMatrix4 cameraMatrix;
@property (nonatomic) CGPoint startTouch;
@property (nonatomic) CGPoint cameraAngle;
@property (nonatomic) CGPoint startCameraAngle;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation OMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.shard = [OMShard new];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

// 900,000 triangles on iPad 2 at 10 frames a second
// that's not very many!
// how many cubes is that?

// 75,000 cubes

- (void)setupGL
{
    // create the context
    [EAGLContext setCurrentContext:self.context];
    // load the shaders
    [self loadShaders];
    
    // make the effect (is used for everything here)
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
//    self.effect.light0.spotDirection = GLKVector3Make(1.0, 1.0, -1.0);
    self.effect.light0.position = GLKVector4Make(-10.0, 0.0, 10.0, 0.0);
    
    self.cameraAngle = CGPointMake(45, 45);
    
    // options
    glEnable(GL_DEPTH_TEST);
    //glEnable(GL_CULL_FACE);
    
    // bind vertex array
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    // TODO: make an array twice the size
    // translated by one point
    
    // bind vertexBuffer to gCubeVertexData
    // you can only put this in setupGL because it is static?
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    // this is how you read that buffer / array thing
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods


// This shows 2 different rendering systems. GLKit vs ES2

- (void)update
{
    // set the projection
    // this makes sense.
    // the problem is: the camera doesn't start at 0
    // so if you rotate it, it just moves around in place, like rotating the earth
    // you want to ORBIT the cube.
    // what you really want is a small rotation for the angle, and a translation to where you expect
    
    // translation is associative and cumulative
    // rotation is WEIRD
    // matrix multiplication is NOT communicative. AxB != BxA
    
    // It starts out at zero, so if you translate then rotate, it rotates AROUND 0
    // which is weird
    
    // You probably want to rotate, THEN translate.
    
    // That's why you always want vertices to be centered around the origin.
    // because otherwise they would rotate strangely
    
    
    // PROJECTION MATRIX
    // transforms the world space to our screen space. this isn't really the camera...
    
    // MODEL MATRIX
    // individual to every single model. rotates and scales the object to its final position in your world
    
    // VIEW MATRIX
    // same for most or all objects. Rotates and moves all objects according to the current camera position
    
    
        float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
//    projectionMatrix = GLKMatrix4Translate(projectionMatrix, 1.0, -1.0, 0);
//    projectionMatrix = GLKMatrix4Rotate(projectionMatrix, GLKMathDegreesToRadians(45), 0.0, 1.0, 1.0);
//    projectionMatrix = GLKMatrix4Rotate(projectionMatrix, GLKMathDegreesToRadians(15), 1.0, 1.0, 0.0);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // this is pretty cool, you can just keep editing it
    // I don't really want to rotate the geometry at all, I just want to move the camera angel
//    _rotation = GLKMathDegreesToRadians(45);
//    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
   //    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
//    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, GLKMathDegreesToRadians(20), 1.0f, 0.0f, 0.0f);
    
//    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5);
//    baseModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    // Compute the model view matrix for the object rendered with GLKit
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
//    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

//    self.effect.transform.modelviewMatrix = baseModelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
//    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
//    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
//    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
//    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
//    _rotation += self.timeSinceLastUpdate * 0.5f;
}

// this is the one that would change when they move
// not the same as update
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.53, 0.80, 0.98f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
//    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 1.0f, -4.0f);
//    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, GLKMathDegreesToRadians(45), 0.0, 0.0, 1.0);
//    self.effect.transform.modelviewMatrix = baseModelViewMatrix;
//    
//    // Render the object with GLKit
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    self.cameraMatrix = [self adjustCameraWithAngle:self.cameraAngle];
    
    [self drawBoxAtLocation:GLKVector3Make(0, 0, 0) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, 0, 0) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, 0, 1) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, 0, 2) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, 1, 1) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, 2, 1) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, -1, 1) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, 1, 0) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(1, -3, 0) withCamera:_cameraMatrix];
    [self drawBoxAtLocation:GLKVector3Make(-1, 1, 0) withCamera:_cameraMatrix];
    
//    baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 1.0f, -4.0f);
//    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, GLKMathDegreesToRadians(45), 1.0, 0, 0);
//    self.effect.transform.modelviewMatrix = baseModelViewMatrix;
//    
//    // Render the object with GLKit
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (GLKMatrix4)adjustCameraWithAngle:(CGPoint)angle {
    GLKMatrix4 camRotate = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(angle.x), 1, 0, 0);
    camRotate = GLKMatrix4Rotate(camRotate, GLKMathDegreesToRadians(angle.y), 0, 1, 0);
    GLKMatrix4 camTranslate = GLKMatrix4MakeTranslation(4, -5, -4.0);
    return GLKMatrix4Multiply(camRotate, camTranslate);
}

- (void)drawBoxAtLocation:(GLKVector3)location withCamera:(GLKMatrix4)cameraMatrix {
    // the one you want to happen first is multiplied LAST
    // camRotate * camScale * camTranslate * objTranslate * objScale * objRotate;
    
    // TODO cache the camera matrix
    // the camera angle remains the same for all objects
    GLKMatrix4 objTranslate = GLKMatrix4MakeTranslation(location.x, location.y, location.z);
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(cameraMatrix, objTranslate);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    self.startTouch = [touch locationInView:self.view];
    self.startCameraAngle = self.cameraAngle;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGPoint angle;
    angle.x = self.startCameraAngle.x + ((self.startTouch.y - location.y) / 2);
    angle.y = self.startCameraAngle.y + ((self.startTouch.x - location.x) / 2);
    self.cameraAngle = angle;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
