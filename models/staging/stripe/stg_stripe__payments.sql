select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    _batched_at,

    -- amount is stored in cents, convert it to dollars
    amount / 100 as amount,
    created as created_at

from {{source('raw_stripe', 'payment')}}