addEventHandler("onClientResourceStart", resourceRoot,
    function()
        myScreenSource = dxCreateScreenSource ( 1920, 1080 )          -- Create a screen source texture which is 640 x 480 pixels
    end
)

addEventHandler( "onClientRender", root,
    function()
        if myScreenSource then
            dxUpdateScreenSource( myScreenSource )
            dxDrawImage( 50,  50,  640, 480, myScreenSource )
        end
    end
)