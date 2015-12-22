// hack for safari inputs when text is not visible as you type it
// the problem is with hardware scrolling acceleration, if it's set

//if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1) {
if (/iPhone|iPod/i.test(navigator.userAgent)) {
    (function(){
        $(document).on('focus', 'input', function(){
            $('#page').css('-webkit-overflow-scrolling', 'auto');
        });
        $(document).on('blur', 'input', function(){
            $('#page').css('-webkit-overflow-scrolling', '');
        });
    })();
}
