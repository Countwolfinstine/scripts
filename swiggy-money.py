"""
Script to find total money spent on swiggy food orders.
"""
import requests


order_list = []
def run_curl(order_id):
    global order_list
    headers = {
        'authority': 'www.swiggy.com',
        'sec-ch-ua': '"Chromium";v="94", "Google Chrome";v="94", ";Not A Brand";v="99"',
        'content-type': 'application/json',
        '__fetch_req__': 'true',
        'sec-ch-ua-mobile': '?1',
        'user-agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Mobile Safari/537.36',
        'sec-ch-ua-platform': '"Android"',
        'accept': '*/*',
        'sec-fetch-site': 'same-origin',
        'sec-fetch-mode': 'cors',
        'sec-fetch-dest': 'empty',
        'referer': 'https://www.swiggy.com/my-account',
        'accept-language': 'en-GB,en-US;q=0.9,en;q=0.8',
        'cookie': '<your cookie>',
        'if-none-match': '<your value>',
    }

    params = (
        ('order_id', order_id),
    )

    response = requests.get('https://www.swiggy.com/mapi/order/all', headers=headers, params=params)

    amount = []
    data = response.json()
    response_order_id_list = []
    for i in data['data']['orders']:        
        response_order_id_list.append(i['order_id'])
        if 'payment_transactions' not in i:            
            break
        for x in i['payment_transactions']:
            amount.append(float(x['amount']))
            print("Amount : {}".format(x['amount']))            
    order_list = order_list + response_order_id_list
    return amount, response_order_id_list[-1]

#Need to update initial order ID
initial_order_id='115134657453'

amount = []

 
for _ in range(0,100):
    amount1,next_order_id= run_curl(initial_order_id)
    initial_order_id = next_order_id
    amount = amount + amount1

print("order count before ", len(order_list))
print("order count after ", len(set(order_list)))
print("Total amount ", sum(amount))
# print(amount,next_order_id )
