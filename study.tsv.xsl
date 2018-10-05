<!--
   Copied from
   https://github.com/dcm4che/dcm4che/tree/master/dcm4che-assembly/src/etc/findscu/study.csv.xsl
   and edited.
   -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>

  <xsl:template match="/NativeDicomModel">
    <xsl:apply-templates select="DicomAttribute[@tag='0020000D']"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:apply-templates select="DicomAttribute[@tag='00201208']"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:apply-templates select="DicomAttribute[@tag='00100010']" mode="PN"/>
    <xsl:text>.</xsl:text>
    <xsl:apply-templates select="DicomAttribute[@tag='00100020']"/>
    <xsl:text>.</xsl:text>
    <xsl:apply-templates select="DicomAttribute[@tag='00080020']"/>
    <xsl:text>T</xsl:text>
    <xsl:apply-templates select="DicomAttribute[@tag='00080030']"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="DicomAttribute">
    <xsl:apply-templates select="Value"/>
  </xsl:template>

  <xsl:template match="DicomAttribute" mode="PN">
    <xsl:apply-templates select="PersonName"/>
  </xsl:template>

  <xsl:template match="Value">
    <xsl:if test="@number != 1">\</xsl:if>
    <xsl:value-of select="text()"/>
  </xsl:template>

  <xsl:template match="PersonName">
    <xsl:if test="@number != 1">\</xsl:if>
    <xsl:apply-templates select="Alphabetic"/>
    <xsl:if test="Ideographic or Phonetic">
      <xsl:text>=</xsl:text>
      <xsl:apply-templates select="Ideographic"/>
      <xsl:if test="Phonetic">
        <xsl:text>=</xsl:text>
        <xsl:apply-templates select="Phonetic"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Alphabetic|Ideographic|Phonetic">
    <xsl:value-of select="FamilyName"/>
    <xsl:if test="GivenName or MiddleName or NamePrefix or NameSuffix">
      <xsl:text>^</xsl:text>
      <xsl:value-of select="GivenName"/>
      <xsl:if test="MiddleName or NamePrefix or NameSuffix">
        <xsl:text>^</xsl:text>
        <xsl:value-of select="MiddleName"/>
        <xsl:if test="NamePrefix or NameSuffix">
          <xsl:text>^</xsl:text>
          <xsl:value-of select="NamePrefix"/>
          <xsl:if test="NameSuffix">
            <xsl:text>^</xsl:text>
            <xsl:value-of select="NameSuffix"/>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
