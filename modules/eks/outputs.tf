output "cluster_name"{ 
    value = aws_eks_cluster.this.name 
}

output "cluster_endpoint"{ 
    value = aws_eks_cluster.this.endpoint 
}

output "oidc_issuer_url"{ 
    value = aws_iam_openid_connect_provider.oidc.url 
}


