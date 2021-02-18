
function LedToggle()
{
   var domP = document.getElementById('ledResult');

   if(domP.innerHTML == "Led is now On")
   {
      domP.innerHTML = "Led is now Off";//改变内容
      domP.style.color="#000000"; //改变样式
   }
   else
   {
      domP.innerHTML = "Led is now On";//改变内容
      domP.style.color="#0000FF"; //改变样式
   }
}