
<div align="center">
  <h1>Wallpaper Gallery</h1>
  <p>A curated collection of stunning wallpapers, ready for one-click deployment.</p>
</div>

## 🚀 One-Click Deployment

Deploy your own wallpaper gallery in a single click using one of the services below:

<div align="center">
  <a href="https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2FRishabh5321%2Fwallpapers"><img src="https://vercel.com/button" alt="Deploy with Vercel"/></a>
  <a href="https://app.netlify.com/start/deploy?repository=https://github.com/Rishabh5321/wallpapers"><img src="https://www.netlify.com/img/deploy/button.svg" alt="Deploy to Netlify"></a>
</div>

## 📸 Screenshots

<div align="center">
  <img src=".github/screenshot/screenshot-20250705-163409.png" alt="Screenshot 1" width="90%">
  <img src=".github/screenshot/screenshot-20250705-163457.png" alt="Screenshot 2" width="45%">
  <img src=".github/screenshot/screenshot-20250705-163526.png" alt="Screenshot 3" width="45%">
</div>

## ✨ Live Gallery

You can view the live wallpaper gallery here: **[Live Gallery](https://rishabh5321-wallpapers.vercel.app/)**

## 📥 Adding New Wallpapers

To add a new wallpaper to your gallery:

1.  **Fork the repository** if you haven't already.
2.  Add your new image file (e.g., `my-cool-wallpaper.png`) to the `src` directory of your forked repository.
3.  Commit and push the changes to your `main` branch.
4.  The GitHub Actions workflow will automatically update the gallery and deploy the changes.

## 🎨 How It Works

This project uses a GitHub Actions workflow to automate the gallery generation process:

1.  **Push to `main`**: When changes are pushed to the `main` branch (e.g., adding a new wallpaper), a workflow is triggered.
2.  **Generate Thumbnails**: The workflow generates smaller thumbnails for each image to ensure the gallery loads quickly.
3.  **Update Gallery**: A shell script (`generate_readme.sh`) runs to scan for all images and injects the list into the `docs/js/gallery-data.js` file.
4.  **Commit Changes**: The updated `gallery-data.js` is automatically committed back to the repository.
5.  **Deployment**: The site is automatically deployed to Vercel and Netlify when changes are pushed to the `main` branch.

## License

The code in this repository is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. The wallpapers are not covered by this license.
