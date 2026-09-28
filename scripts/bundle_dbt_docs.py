import json
import os

def bundle_dbt_docs():
    target_dir = "dbt_project/target"
    index_path = os.path.join(target_dir, "index.html")
    manifest_path = os.path.join(target_dir, "manifest.json")
    catalog_path = os.path.join(target_dir, "catalog.json")

    if not all(os.path.exists(p) for p in [index_path, manifest_path, catalog_path]):
        print("Error: Missing dbt artifacts. Run 'dbt docs generate' first.")
        return

    with open(index_path, "r", encoding="utf-8") as f:
        html = f.read()
    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = f.read()
    with open(catalog_path, "r", encoding="utf-8") as f:
        catalog = f.read()

    # Inject JSON payloads directly into index.html script tags
    search_manifest = 'loadProjectFile("manifest.json", "manifest", false);'
    search_catalog = 'loadProjectFile("catalog.json", "catalog", false);'

    bundled_html = html.replace(search_manifest, f'window.parent.manifest = {manifest};')
    bundled_html = bundled_html.replace(search_catalog, f'window.parent.catalog = {catalog};')

    output_path = "dbt_project/standalone_dbt_lineage.html"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(bundled_html)

    print(f"Successfully generated standalone dbt lineage graph at: {output_path}")

if __name__ == "__main__":
    bundle_dbt_docs()
