package kubernetes.pod_security

import rego.v1

test_denies_missing_run_as_non_root if {
	count(deny) > 0 with input as {
		"kind": "Deployment",
		"metadata": {"name": "insecure-app"},
		"spec": {
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": false},
				},
			},
		},
	}
}

test_allows_run_as_non_root if {
	count(deny) == 0 with input as {
		"kind": "Deployment",
		"metadata": {"name": "hardened-app"},
		"spec": {
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": true},
				},
			},
		},
	}
}

test_denies_missing_container_resources if {
	count(deny) > 0 with input as {
		"kind": "Deployment",
		"metadata": {"name": "no-resources-app"},
		"spec": {
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": true},
					"containers": [
						{
							"name": "app",
							"image": "ghcr.io/example/sample-app@sha256:1111111111111111111111111111111111111111111111111111111111111111",
							"imagePullPolicy": "Always",
						},
					],
				},
			},
		},
	}
}

test_local_allows_single_replica_and_local_tag if {
	count(deny) == 0 with input as {
		"environment": "local",
		"kind": "Deployment",
		"metadata": {"name": "local-app"},
		"spec": {
			"replicas": 1,
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": true},
					"containers": [
						{
							"name": "app",
							"image": "devsecops-engine:0.1.0-local",
							"imagePullPolicy": "IfNotPresent",
							"resources": {
								"requests": {"cpu": "100m", "memory": "128Mi"},
								"limits": {"cpu": "500m", "memory": "256Mi"},
							},
						},
					],
				},
			},
		},
	}
}

test_prod_denies_mutable_tag_and_single_replica if {
	count(deny) > 0 with input as {
		"environment": "prod",
		"kind": "Deployment",
		"metadata": {"name": "prod-app"},
		"spec": {
			"replicas": 1,
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": true},
					"containers": [
						{
							"name": "app",
							"image": "ghcr.io/example/sample-app:latest",
							"imagePullPolicy": "IfNotPresent",
							"resources": {
								"requests": {"cpu": "250m", "memory": "256Mi"},
								"limits": {"cpu": "1000m", "memory": "512Mi"},
							},
						},
					],
				},
			},
		},
	}
}

test_prod_allows_hardened_digest_and_replicas if {
	count(deny) == 0 with input as {
		"environment": "prod",
		"kind": "Deployment",
		"metadata": {"name": "prod-app"},
		"spec": {
			"replicas": 2,
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": true},
					"containers": [
						{
							"name": "app",
							"image": "ghcr.io/example/sample-app@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
							"imagePullPolicy": "Always",
							"resources": {
								"requests": {"cpu": "250m", "memory": "256Mi"},
								"limits": {"cpu": "1000m", "memory": "512Mi"},
							},
						},
					],
				},
			},
		},
	}
}
