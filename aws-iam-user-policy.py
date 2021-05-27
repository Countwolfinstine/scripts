"""
Write a script which will list out all IAM users and their corresponding IAM policies given an AWS Account.
"""
import boto3

iam = boto3.resource('iam') 

def main():
    """Script to find a list of policy: user"""
    
    policy_map = {}
    user_iterator = iam.users.all()

    # iterating over all the users and creating policy map
    for user in  user_iterator:
        policy_iterator = user.attached_policies.all()

        for policy in policy_iterator:
            if policy.policy_name not in policy_map:
                policy_map[policy.policy_name] = (user.user_name)
            else:
                policy_map[policy.policy_name] = policy_map[policy.policy_name].append(user.user_name)

    # iterating over all the groups and updating policy map
    group_iterator = iam.groups.all()
    
    for group in group_iterator:
        user_list = []
        policy_list = []

        # getting list of users names
        for user in group.users.all():
            user_list.append(user.user_name)

        policy_iterator = group.attached_policies.all()
        for policy in policy_iterator :
            policy_list.append(policy.policy_name)

        for policy in policy_iterator:
            if policy not in policy_map:
                policy_map[policy.policy_name] = set(user_list)
            else:
                 policy_map[policy.policy_name] = set(set(policy_map[policy.policy_name]) + set(append(user.user_name)))

    for policy in policy_map:
        print ("{} : {}".format(policy,policy_map[policy]))


if __name__ == '__main__':
    main()
