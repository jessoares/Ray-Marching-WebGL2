var mesh, timer, shaderProgram;
let uPosition, uTime, uResolution;

var start = function() {
    initCanvas();
    timer = new Timer();
    shaderProgram = new Shader('vertShader', 'fragShader');
    shaderProgram.UseProgram();

    var vertices = [-1.0, -1.0,
                     1.0,  1.0,
                    -1.0,  1.0,
                     1.0, -1.0];
    var indices = [2, 0, 1,
                   1, 0, 3];
    mesh = new Mesh(vertices, indices, shaderProgram);

    drawScene();
};

var initCanvas = function() {
	canvas = document.getElementById('canvas');
    gl = canvas.getContext('webgl2');  
	gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); 
    
}


var drawScene = function() {
    normalSceneFrame = window.requestAnimationFrame(drawScene);
    resize(gl.canvas);
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
    gl.clearColor(0.53, 0.81, 0.92, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    timer.Update();
    shaderProgram.SetUniformVec2("resolution", [gl.canvas.width, gl.canvas.height]);
    shaderProgram.SetUniform1f("time", timer.GetTicksInRadians());
    mesh.Draw();
}

var resize = function(canvas) {
    var displayWidth  = canvas.clientWidth;
    var displayHeight = canvas.clientHeight;

    if (canvas.width  !== displayWidth || canvas.height !== displayHeight) {
        canvas.width  = displayWidth;
        canvas.height = displayHeight;
        aspectRatio = displayWidth / displayHeight;
    }
}
