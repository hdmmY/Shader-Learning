Shader  "Custom/Test_01"
{
    Properties
    {
        _Int("My_Int", Int) = 0
        _Float("My_Float", Float) = 2.0
        _Range("My_Range", Range(9.0, 5.0)) = 2.0
        _Color("My_Color", Color) = (1, 1, 1, 1)
        _Vector("My_Vector", Vector) = (2, 5, 6, 7)
        _2D("My_2D_Texture", 2D) = "white" {}
        _Cube("My_Cube_Texture", Cube) = "black" {}
        _3D("My_3D_Texture", 3D) = "bump" {}
    }

    

    FallBack "Diffuse"
}