{
  description = "A Nix-flake-based GCP kubernetes/terraform environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          crane
          kubecolor
          kubectl
          kustomize
          (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
          kubernetes-helm
          k9s
          openssl
          cmctl
          terraform
          nodejs
        ];

        shellHook = ''
          echo
          echo "GCP - kubernetes: "
          echo
          echo " - ${pkgs.kubectl.name} / ${pkgs.kubecolor.name}"
          echo " - ${pkgs.kustomize.name}"
          echo " - ${pkgs.kubernetes-helm.name}"
          echo " - ${pkgs.k9s.name}"
          echo " - ${pkgs.terraform.name}"
          echo " - ${pkgs.google-cloud-sdk.name}"

          export GCP_HOME="/wa/infra/k8s/w-saleor-1"
          export KUBECONFIG="$GCP_HOME/kubeconfig"
          export KUBE_CONFIG_PATH=$KUBECONFIG

          # Add bash autocomplete for kubernetes
          alias k=kubecolor
          source <(${pkgs.kubectl}/bin/kubectl completion bash)
          complete -o default -F __start_kubectl k

          echo
          echo " - GCP_HOME=$GCP_HOME"
          echo " - KUBECONFIG=$KUBECONFIG"
          echo
          echo " - KUBE_CONFIG_PATH=$KUBE_CONFIG_PATH"
          echo
          echo "GCLOUD set to GCP env"
          echo
          echo "use k alias to run kubecolor.  Autocomplete is also enabled."
          alias tp='terraform plan -var-file=./envs/gke.tfvars'
          alias ta='terraform apply -var-file=./envs/gke.tfvars'
          alias tpf='terraform plan -target=module.saleor_platform -var-file=./envs/gke.tfvars'
          alias taf='terraform apply -target=module.saleor_platform -var-file=./envs/gke.tfvars'
          alias tps='terraform plan -target=module.saleor_storefront -var-file=./envs/gke.tfvars'
          alias tas='terraform apply -target=module.saleor_storefront -var-file=./envs/gke.tfvars'
        '';
      };
    });
  };
}
