(function (window) {
    var STYLE_ID = 'HideMobileUpsellButton-StyleTag';

    function injectCSS(css) {
        if (document.getElementById(STYLE_ID)) {
            return;
        }
        var head = document.getElementsByTagName('head')[0];
        var style = document.createElement('style');
        style.id = STYLE_ID;
        style.innerHTML = css;
        head.appendChild(style);
    }

    window.addEventListener('DOMContentLoaded', function () {
        injectCSS(
            'a.MobileUpsellFooterButtonView { display: none !important; }'
        );
    });
})(window);
