"use strict";

let countdown = 0;

function handleError(msg) {
    $('#error-text').html(msg);
}

function resetErrorText() {
    $('#error-text').html('');
}

$('#get-otp').click(() => {
    const phoneNumber = $('#phone').val();
    $.ajax({
        type: "post",
        url: "{{ url('ajax-get-otp') }}",
        data: {
            csrftoken: '{{ csrf_token_ajax() }}',
            phoneNumber: phoneNumber,
            isRegister: $('#is-register').val()
        },
        dataType: "json",
        success: (data) => {
            if (data.status == 200) {
                countdown = data.data;
                resetErrorText();
                $('#get-otp').hide();
                $('#otp-countdown').show();
                $('#get-otp-modal-phone').html(phoneNumber);
                $('#get-otp-modal').modal();
            } else {
                handleError(data.data);
            }
        },
        error: (ex) => handleError(ex)
    });
});


var x = setInterval(function() {
    if (countdown > 0) {
        countdown--;
        $('#otp-countdown').html(countdown);
    }
    if (countdown <= 0) {
        timeup();
    }
}, 1000);

function timeup() {
    $('#otp-countdown').hide();
    $('#get-otp').show();
}