
function celsiusToFahrenheit(c) {
    const f = c * (9/5) + 32;
    console.log(`${c}°C  = ${f}°F`);
}

function fahrenheitToCelsius(f) {
    const c = (f-32) * (5/9);
    console.log(`${f}°F is ${c}°C`);
}

celsiusToFahrenheit(0);
celsiusToFahrenheit(100);
celsiusToFahrenheit(-40);
fahrenheitToCelsius(98.6);