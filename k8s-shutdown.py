"""
Script to scale down or scale up all the deployments in namespace
"""
import argparse
import time
from kubernetes import client, config


def get_application_namespaces():
    """ Return a list of application namespaces """
    namespace_list = {}
    namespace_list_object= apiV1Core.list_namespace()

    for namespace in namespace_list_object.items:
        if  namespace.metadata.labels is not None  and 'team' in namespace.metadata.labels:
            namespace_list[namespace.metadata.name] = namespace.metadata.labels["team"]
    return namespace_list

def start_datasources(namespace):
    deployments_object  = apiV1.list_namespaced_deployment(namespace)

    for deployment in deployments_object.items:
        if "app.kubernetes.io/service" in deployment.metadata.labels and deployment.metadata.labels["app.kubernetes.io/service"] == "database":
            scale_object = apiV1.read_namespaced_deployment_scale(namespace=namespace,
            name=deployment.metadata.name)
            scale_object.spec.replicas = 1
            apiV1.patch_namespaced_deployment_scale(namespace=namespace,
            name=deployment.metadata.name, body=scale_object)

def check_database_deployment_status(namespace):
    status = True
    deployments_object  = apiV1.list_namespaced_deployment(namespace)
    for deployment in deployments_object.items:
        if "app.kubernetes.io/service" in deployment.metadata.labels and deployment.metadata.labels["app.kubernetes.io/service"] == "database":
            status_object = apiV1.read_namespaced_deployment_status(namespace=namespace,
            name=deployment.metadata.name)
            if (status_object.status.available_replicas == None):
                status = False
                print("{} Database is not up".format(deployment.metadata.name))
    return status

def scale_all_deployments(namespace, team_name, action):
    """ Scale all deployments in namespace """
    status = True
    if action == 'start':
        start_datasources(namespace)
        for i in range(0,30):
            status = check_database_deployment_status(namespace)
            if status == False:
                print("sleeping for 20 seconds")
                time.sleep(20)
            else:
                break
    if status == False:
        print("Unable to start databases. Exiting. Please check the errors in databases")
        exit(1)

    deployments_object  = apiV1.list_namespaced_deployment(namespace)
    for deployment in deployments_object.items:
        scale_object = apiV1.read_namespaced_deployment_scale(namespace=namespace,
            name=deployment.metadata.name)

        print("Namespace = {:20s};  Service = {:30s}; Replicas = {} ".format(namespace,
         deployment.metadata.name, scale_object.spec.replicas))

        if action == 'stop':
            scale_object.spec.replicas = 0
        elif action == 'start':
            if "app.kubernetes.io/service" not in deployment.metadata.labels or deployment.metadata.labels["app.kubernetes.io/service"] != "database":
                if team_name in ["qa_smoke_suite", "qa_regression_suite", "app_automation", "qa_automation"]:
                    scale_object.spec.replicas = 6
                else:
                    scale_object.spec.replicas = 1


        print("Namespace = {:20s};  Service = {:30s}; Replicas = {} (updated)".format(namespace,
         deployment.metadata.name, scale_object.spec.replicas))

        apiV1.patch_namespaced_deployment_scale(namespace=namespace,
            name=deployment.metadata.name, body=scale_object)

def main():
    """ main function"""
    global apiV1
    global apiV1Core
    global apiV2

    parser = argparse.ArgumentParser(description='Script to scale down staging kubernetes cluster')

    parser.add_argument('--proxy',
     help='Proxy url used by kubernetes', required=True )
    parser.add_argument('--namespace',
     help='namespace in kubernetes to stop or start, type all for all application namespaces',
     required=True)
    parser.add_argument('--action',
     help='stop or start all the service in namespace', required=True )
    args = parser.parse_args()

    # proxy_url = 'http://10.12.0.28:8118'
    proxy_url = args.proxy
    config.load_kube_config()
    client.Configuration._default.proxy = proxy_url

    apiV1 = client.AppsV1Api()
    apiV1Core = client.CoreV1Api()
    apiV2 = client.AppsV1Api()

    list_of_namespaces = get_application_namespaces()

    if args.namespace == 'all':
        print("List of Application namespaces which are getting scaled ", list_of_namespaces)
        for namespace in list_of_namespaces.keys():
            scale_all_deployments(namespace, list_of_namespaces[namespace], args.action)
    else:
        if args.namespace not in list_of_namespaces.keys():
            print("List of Application namespaces", list_of_namespaces.keys())
            print("Environment/namespace not found or its a system namespace.\
             Please verify the name")
        else:
            scale_all_deployments(args.namespace, list_of_namespaces[args.namespace], args.action)

if __name__ == '__main__':
    main()
