c.JupyterHub.api_tokens = { 'proxy-token': 'PROXY_TOKEN' }
c.JupyterHub.authenticator_class = 'ldapauthenticator.LDAPAuthenticator'
c.LDAPAuthenticator.server_address = 'ldap-apps.stern.nyu.edu'
c.LDAPAuthenticator.bind_dn_template = ['uid={username}, ou=people, dc=stern,dc=nyu,dc=edu']
c.LDAPAuthenticator.use_ssl = True
c.Authenticator.admin_users = {'ADMIN_USER_1', 'ADMIN_USER_2', ...}
c.JupyterHub.admin_access = True

c.KubeSpawner.environment = {"GRADING_PROXY_ADDR" : "...", "GOOGLE_APPLICATION_CREDENTIALS": "/etc/da-access/..."}
c.KubeSpawner.singleuser_image_pull_policy = "IfNotPresent"

c.KubeSpawner.user_storage_pvc_ensure = True
c.KubeSpawner.pvc_name_template = 'claim-{username}'
c.KubeSpawner.user_storage_capacity = '10Gi'
c.KubeSpawner.singleuser_privileged = True
c.KubeSpawner.singleuser_service_account = '...'

c.KubeSpawner.volume_mounts = [{"name" : "volume-{username}", "mountPath" : "/home/{username}"}, {"name" : "nfs", "mountPath" : "/home/{username}/assignments"}, {"name" : "da-access", "mountPath" : "/etc/da-access"}]
c.KubeSpawner.volumes = [{"name" : "volume-{username}", "persistentVolumeClaim" : {"claimName" : "claim-{username}"}}, {"name" : "nfs", "persistentVolumeClaim" : {"claimName" : "nfs"}}, {"name" : "da-access", "secret" : { "secretName": "dataset-access" }}]
c.KubeSpawner.cmd = 'start-notebook.sh'
c.KubeSpawner.start_timeout = 180
c.KubeSpawner.http_timeout = 180
c.KubeSpawner.singleuser_uid = 1000

def cluster_admin_env(spawner, pod):
        # name template is jupyterhub-nb-{username}
        username = (pod.metadata.name.split('-')[-1]
        is_admin = '0'
        if username in c.Authenticator.admin_users:
            is_admin = '1'

        pod.spec.containers[0].env.append({'name' : 'USER_IS_CLUSTER_ADMIN', 'value' : is_admin})

        return pod

c.KubeSpawner.modify_pod_hook = cluster_admin_env
