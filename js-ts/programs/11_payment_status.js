const paymentStatus = "PAID";

switch(paymentStatus){
    case "PENDING": 
        console.log("Waiting for payment");
        break;
    case "PAID":
        console.log("Payment received");
        break;
    case "SHIPPED":
        console.log("On the way");
        break;
    default:
        console.log("Unknown status");
}