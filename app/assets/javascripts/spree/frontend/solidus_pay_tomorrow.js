let ptOrderNumber;
let ptPaymentMethodId;
let orderToken;

document.addEventListener('DOMContentLoaded', async function () {
    const createOrderPayload = document.getElementById(
        'pay-tomorrow-order-payload'
    );
    if (createOrderPayload){
        ptOrderNumber = createOrderPayload.dataset.ptOrderNumber;
        ptPaymentMethodId = createOrderPayload.dataset.ptPaymentMethodId
        orderToken = createOrderPayload.dataset.orderToken;
    }
})

async function createOrder() {
    const createOrderResponse = await createPayTomorrowOrder();
    const createOrderStatusDiv = document.getElementById('create-order-status-container');
    if (createOrderResponse.ok) {
        document.getElementById("card-container").remove()
        document.getElementById("pay-tomorrow-card-button").remove()
        createOrderStatusDiv.innerHTML = "<strong>URL generated. Redirecting to payTomorrow to complete the payment...<strong>"
    } else {
        createOrderStatusDiv.innerHTML = "Payment Failed"
    }
    return createOrderResponse.json();
}

async function createPayTomorrowOrder() {
    const body = JSON.stringify({
        payment_method: ptPaymentMethodId
    });
    const resp = await fetch('/api/orders/' + ptOrderNumber + '/pay_tomorrow', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Spree-Order-Token': orderToken
        },
        body,
    });
    return resp
}

document.addEventListener('DOMContentLoaded', async function () {
    const cardButton = document.getElementById('pay-tomorrow-card-button');
    cardButton.addEventListener('click', async function () {
        cardButton.disabled = true;
        const response = await createOrder();
        if (response.hasOwnProperty('url')) {
            window.open(response.url, '_self')
        } else {
            cardButton.disabled = false;
        }
    });
});

