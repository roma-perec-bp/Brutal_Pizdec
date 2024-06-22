var chromatic = game.createRuntimeShader('vcr');
var chromaticFilter = new ShaderFilter(chromatic);
var radial = game.createRuntimeShader('radialBlur');
var radialFilter = new ShaderFilter(radial);
var chromacrap = 0;
var bullshit = 0;

var chromOn:Bool = false;

function onCreate()
{
    game.initLuaShader('vcr');
    game.initLuaShader('radialBlur');
}

function onBeatHit()
{
    if(chromOn)
    {
        chromacrap = 0.01;
        bullshit = 0.07;
    }
}

function setChrome(chromeOffset)
{
    chromatic.setFloat("rOffset", chromeOffset);
    chromatic.setFloat("gOffset", 0.0);
    chromatic.setFloat("bOffset", chromeOffset * -1);
}

function onUpdate(elapsed) {
    if(chromOn)
    {
        if(chromacrap >= 0) chromacrap -= 0.001;
        setChrome(chromacrap);
    
        if(bullshit >= 0) bullshit -= 0.01;
        radial.setFloat('blurWidth', bullshit);
    }
}

function onCreatePost()
{
    radial.setFloat("cx", 0.5);
    radial.setFloat("cy", 0.5);
    radial.setFloat("blurWidth", 0);
}

function onStepHit()
{
    switch (curStep)
    {
        case 1664:
            chromOn = true;
            game.camHUD.setFilters([chromaticFilter]);
            game.camGame.setFilters([chromaticFilter, radialFilter]);
        case 2176:
            chromOn = false;
            game.camGame.setFilters([]);
            game.camHUD.setFilters([]);
    }
}

function onDestroy()
{
    game.camGame.setFilters([]);
    game.camHUD.setFilters([]);
}