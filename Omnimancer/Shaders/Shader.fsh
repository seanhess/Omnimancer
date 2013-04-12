//
//  Shader.fsh
//  Omnimancer
//
//  Created by Sean Hess on 4/9/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
