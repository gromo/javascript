angular.module("MODULE").directive("select", function ($interval) {
    return {
        link: function (scope, element, attrs) {
            var interval, optionsModel;

            if (scope.ngOptions && /\sin\s/.test(scope.ngOptions)) {
                optionsModel = scope.ngOptions.replace(/.*\sin\s([^ ]+).*/, '$1');
            }

            scope.values = [];
            scope.visible = element.is(':visible');

            scope.$watch('ngDisabled', function () {
                if (scope.visible) {
                    console.log('update custom select');
                }
            });

            scope.$watch('values', function () {
                setTimeout(function () {
                    if (scope.visible) {
                        console.log('update custom select');
                    }
                }, 100);
            });

            scope.$watch('visible', function (visible) {
                if (visible) {
                    console.log('init custom select');
                } else {
                    console.log('destroy custom select');
                }
            });

            element.on('$destroy', function () {
                $interval.cancel(interval);
                console.log('destroy custom select');
            });

            interval = $interval(function () {
                if (optionsModel) {
                    scope.values = scope.$parent[optionsModel];
                }
                scope.visible = element.is(':visible');
            }, 300);

            if (scope.visible) {
                console.log('init custom select');
            }
        },
        restrict: 'E',
        scope: {
            ngDisabled: '=',
            ngOptions: '@'
        }
    };
});