using System;
using System.Diagnostics;
using System.IO;
using System.Text;

internal static class ArenaLabBootstrap
{
    private const string Payload = "@@PAYLOAD_BASE64@@";

    [STAThread]
    private static int Main()
    {
        string scriptPath = Path.Combine(Path.GetTempPath(), "ArenaLab-" + Guid.NewGuid().ToString("N") + ".ps1");
        try
        {
            File.WriteAllBytes(scriptPath, Convert.FromBase64String(Payload));
            string powershell = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "WindowsPowerShell\\v1.0\\powershell.exe");
            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = powershell;
            start.Arguments = "-NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File \"" + scriptPath + "\"";
            start.UseShellExecute = true;
            start.WindowStyle = ProcessWindowStyle.Normal;
            using (Process child = Process.Start(start))
            {
                child.WaitForExit();
                return child.ExitCode;
            }
        }
        catch (Exception error)
        {
            System.Windows.Forms.MessageBox.Show(error.Message, "Arena Lab installer");
            return 1;
        }
        finally
        {
            try { if (File.Exists(scriptPath)) File.Delete(scriptPath); } catch { }
        }
    }
}
