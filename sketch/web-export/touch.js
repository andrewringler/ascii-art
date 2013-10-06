var hammertime = Hammer(document.getElementById('sketch'), {
    transform_always_block: true,
    transform_min_scale: 1,
    drag_block_horizontal: true,
    drag_block_vertical: true,
    drag_min_distance: 0
});

var hammertime_posX=0, hammertime_posY=0,
        hammertime_scale=1, hammertime_last_scale,
        hammertime_rotation= 1, hammertime_last_rotation;
hammertime.on('touch drag transform', function(ev) {
        switch(ev.type) {
            case 'touch':
                hammertime_last_scale = hammertime_scale;
                hammertime_last_rotation = hammertime_rotation;
                break;

            case 'drag':
                hammertime_posX = ev.gesture.deltaX;
                hammertime_posY = ev.gesture.deltaY;
                break;

            case 'transform':
                hammertime_rotation = hammertime_last_rotation + ev.gesture.rotation;
                hammertime_scale = Math.max(1, Math.min(hammertime_last_scale * ev.gesture.scale, 10));
                break;
		}
		console.log('scale '+hammertime_scale+' drag '+hammertime_posX+','+hammertime_posY);
    });