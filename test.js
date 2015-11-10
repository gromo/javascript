/**
 *
 * @param int value
 * @param object limits: minColor, maxColor, minValue, maxValue
 * @returns array rgba
 */
function getValueColor(value, limits) {
    var minColor = hexToRgb(limits.minColor),
        maxColor = hexToRgb(limits.maxColor),
        valueOffset = (value - limits.minValue) / Math.abs(limits.maxValue - limits.minValue), // %
        R = (maxColor.r - minColor.r) * valueOffset + minColor.r,
        G = (maxColor.g - minColor.g) * valueOffset + minColor.g,
        B = (maxColor.b - minColor.b) * valueOffset + minColor.b;
    return rgbToHex(R, G, B);

    function hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }
    function rgbToHex(r, g, b) {
        return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }
}
